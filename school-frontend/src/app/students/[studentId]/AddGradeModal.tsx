'use client';

import { Button, Form, FormInstance, Modal, Select, Slider } from 'antd';
import React, { useRef, useState } from 'react';
import { GoPlus } from 'react-icons/go';

interface TeacherData {
    name: string;
    id: number;
}

interface GradeValueData {
    id: number;
    name: string;
}

interface AddGradeModalProps {
    onSubmit: (formData: any) => Promise<void>;
    teachers: TeacherData[];
    gradeValues: GradeValueData[];
    subjectName: string;
}

export const AddGradeModal: React.FC<AddGradeModalProps> = ({
    teachers,
    gradeValues,
    onSubmit,
    subjectName,
}) => {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const formRef = useRef<FormInstance<any>>(null);

    return (
        <>
            <Button
                size="small"
                title="Add grade"
                icon={<GoPlus />}
                onClick={() => setIsModalOpen(true)}
            />
            <Modal
                open={isModalOpen}
                onCancel={() => setIsModalOpen(false)}
                onOk={() => {
                    console.log(formRef.current);
                    formRef.current?.submit();
                }}
                title={`Add grade for ${subjectName}`}
            >
                <Form
                    onFinish={onSubmit}
                    ref={formRef}
                >
                    <Form.Item
                        label="Grade"
                        name="gradeValueId"
                    >
                        <Select
                            options={gradeValues.map(({ id, name }) => ({
                                label: name,
                                value: id,
                            }))}
                        />
                    </Form.Item>
                    <Form.Item
                        label="Weight"
                        name="weight"
                    >
                        <Slider
                            min={0.1}
                            max={5}
                            step={0.1}
                            defaultValue={1}
                        />
                    </Form.Item>
                    <Form.Item
                        label="Issuer"
                        name="issuerId"
                    >
                        <Select
                            options={teachers.map(({ id, name }) => ({
                                label: name,
                                value: id,
                            }))}
                            showSearch
                            filterOption={(input, option) =>
                                (option?.label ?? '')
                                    .toLowerCase()
                                    .includes(input.toLowerCase())
                            }
                        />
                    </Form.Item>
                </Form>
            </Modal>
        </>
    );
};
